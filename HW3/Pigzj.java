
import java.io.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.nio.channels.FileChannel;
import java.io.FileDescriptor;
import java.io.FileOutputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.zip.CRC32;
import java.util.zip.Deflater;

import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Callable;
import java.util.concurrent.Future;



public class Pigzj {
	
	public final static int BLOCK_SIZE = 131072; //size of compression block=128*1024
	public final static int DICT_SIZE = 32768; //size of priming dictionary block=32*1024
	private final static int GZIP_MAGIC = 0x8b1f;
	private final static int TRAILER_SIZE =   8;
	
	public static FileOutputStream writeData = new FileOutputStream(FileDescriptor.out);
	public static FileChannel writeInfo = new FileOutputStream(FileDescriptor.out).getChannel();

	
	public static void writeHeader() 
	{
		try
		{
			ByteBuffer header = ByteBuffer.allocate(10);
			header.order(ByteOrder.LITTLE_ENDIAN);
			header.putInt(0x00088B1F).putInt((int)(System.currentTimeMillis()/1000L)).putShort((short)0xFF00);
			header.flip();
			writeInfo.write(header);
		}
		catch (IOException err)
		{
			System.err.println("Header error");
		}
	}

	
	public static void main(String[] args) 
    { 
    	try
    	{
		int processors = Runtime.getRuntime().availableProcessors();

		for (int i = 0; i < args.length; i++)
		{
			if (args[i].equals( "-p")) 
			{
				try 
				{
					i++;
					int number = Integer.parseInt(args[i]);
					if (number > processors) 
					{	
						System.err.println("Pigzj: resource unavailable (Pigzj.java:error:create)");
					}
					else
					{
						processors = Integer.parseInt(args[i]);
					}
					continue;
				}
				catch (ArrayIndexOutOfBoundsException err)
				{
					System.err.println("Array index is out of bounds! Enter number of processors ");
					System.exit(1);
				}
				catch (NumberFormatException err)
				{
					System.err.println("Number Format error! Enter an integer number of processors ");
					System.exit(1);
				}
			}
			else 
			{
				System.err.println("Invalid arguments ");
				System.err.println("-p: use specified integer number of processors ");
				System.exit(1);
			}
		}
		CRC32 crc = new CRC32();
		crc.reset();
		
		ExecutorService executor = Executors.newFixedThreadPool(processors);
		List<Future<byte[]>> arrayList = new ArrayList<Future<byte[]>>();


		int totalSize = 0;
		BufferedInputStream stream = new BufferedInputStream(System.in);
		byte[] byte_buffer = new byte[BLOCK_SIZE];
		byte[] dict_buffer = new byte[DICT_SIZE];

		int counter = stream.read(byte_buffer, 0, BLOCK_SIZE); 
		for (;
			 counter == BLOCK_SIZE; 
			 counter = stream.read(byte_buffer, 0, BLOCK_SIZE))
		{
			crc.update(byte_buffer, 0, counter); 
			totalSize += byte_buffer.length;


			Callable<byte[]> current = new CompressThread(byte_buffer,dict_buffer);
			Future<byte[]> submit = executor.submit(current);
			arrayList.add(submit);
			

			dict_buffer = new byte[DICT_SIZE];
			dict_buffer = Arrays.copyOfRange(byte_buffer, BLOCK_SIZE-DICT_SIZE, BLOCK_SIZE);

			byte_buffer = new byte[BLOCK_SIZE];
		}

		if (counter > 0)
		{
			byte[] leftovers_buffer = new byte[counter];
			System.arraycopy(byte_buffer, 0, leftovers_buffer, 0, counter);
			crc.update(leftovers_buffer, 0,counter);
			totalSize += leftovers_buffer.length;

			Callable<byte[]> current2 = new CompressThread(leftovers_buffer, dict_buffer);
			Future<byte[]> submit2 = executor.submit(current2);
			arrayList.add(submit2);
		} 
		executor.shutdown();	
		writeHeader();
		
		for (Future<byte[]> future : arrayList)
		{
			byte[] next = future.get();
			try
			{
				writeData.write(next, 0, next.length);
			}
			catch (IOException err)
			{
				System.err.println("IO error!");
					System.exit(1);
			}
		}
		writeTrailer((int)crc.getValue(), totalSize);
		} catch (Exception err) {err.printStackTrace();}
	}
	public static void writeTrailer(int num, int size)
	{
		try
		{
			ByteBuffer trailer = ByteBuffer.allocate(TRAILER_SIZE);
			trailer.order(ByteOrder.LITTLE_ENDIAN);
			trailer.putInt(num).putInt((int)(size % Math.pow(2,32)));
			trailer.flip();
			writeInfo.write(trailer);
		}
		catch (IOException err)
		{
			System.err.println("IO error");
		}
	}
}