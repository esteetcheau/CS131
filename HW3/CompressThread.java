
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.util.zip.CRC32;
import java.util.zip.Deflater;
import java.io.FileDescriptor;
import java.io.FileOutputStream;
import java.util.concurrent.Callable;
import java.util.Arrays;

public class CompressThread implements Callable<byte[]> 
{
	public static final int BLOCK_SIZE = 131072;
	
	public final byte[] dict;
	public final byte[] bytesIn;

	public CompressThread(final byte[] bytesIn, final byte[] dict)
	{
		this.bytesIn = bytesIn;
		this.dict = dict;
	}
    
	public byte[] call()
    {
			Deflater compressed = new Deflater(Deflater.DEFAULT_COMPRESSION, true);
			byte[] buffer = new byte[BLOCK_SIZE];

			
			compressed.setInput(bytesIn);
			if (dict.length > 0)
				compressed.setDictionary(dict); 
			
			int compressedLength = 0;
			if (bytesIn.length < BLOCK_SIZE) 
			{
				compressed.finish();
				compressedLength = compressed.deflate(buffer, 0, buffer.length, Deflater.NO_FLUSH);
			}
			else
			{
				compressedLength = compressed.deflate(buffer, 0, buffer.length, Deflater.SYNC_FLUSH);
			}
			
			compressed.end();
			byte[] bufferUpdated = new byte[compressedLength];
			bufferUpdated = Arrays.copyOf(buffer, compressedLength);
			return bufferUpdated; 
	}
}