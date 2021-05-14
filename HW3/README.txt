I started with the starter code that was provided to us by the TA's. Next, I tried
to understand how their writeHeader and writeTrailer method worked and implemented 
them into my own version, which has writeInt and writeShort, from the starter code,
included within the writeHeader and writeTrailer methods. This was easier for me
to understand and clearly see the logic of how they worked. At the top, I first 
included a public static int BLOCK_SIZE which was the size of compression block =
128*1024, and the DICT_SIZE, which was the size of the dictionary block = 32*1024.
Next, I had a private variable GZIP_MAGIC, which is the GZIP header magic number, and
finally I had the TRAILER_SIZE, which was the trailer size in bytes = 8. Next, I had a 
public FileOutputStream and FileChannel to write info and data. Then, I declared a 
private CRC32 named crc.

My writeHeader method works like the one provided in the started code, but uses
try/catch to catch the exceptions. The starter code calls the outStream, but after 
research I found that importing java.nio.ByteBuffer and a few other java importations
came in particularly handy. I used the putInt, order, and flip methods from within Byte
Buffer to ensure the header was in little endian order, and the GZIP header magic number
was used as well as using a common currentTimeMillis method to calculate the current
time in milliseconds and then diving it by 1000L. writeShort from the starter code used 
the buffer and offset to write the short integer in Intel byte order to a byte array,
starting at a given offset, but my code simply uses the putShort method sending it
(short)0xFF00. This should work in the same way as the starter code. I got all my 
imported headers from the oracle documentation provided. Finally I used the flip method 
to flip the ByteBuffer from reading from input or output to writing to input or output.

The writeTrailer method provided writes the GZIP member trailer to a byte array, 
starting at a given offset by calling writeInt, which writes integers in Intel byte 
order to a byte array, starting at a given offset, and using the CRC32 that was declared.
My version again utilizes ByteBuffer to allocate the trailer size, ensure it is in
little endian order, and assign the appropriate (int)crc.getValue() and 
total_size (this is sent as the input to calling the method at the end of main). 
total_size is modulo-ed with 2^32 and sent to putInt. Again, we flip the read/write 
of the trailer and use infoWriter. For both the writeHeader and writeTrailer, we used 
the catch to catch IOExceptions and subsequently bring an system error message.

My main function starts off with a try/catch block to catch errors. It parses the 
command line arguments and checks if "-p" was used, indicating that we want to 
set the number of processors. If this is the case, we set a variable number to
the Integer.parseInt(args[i]) and check for exceptions. If it is greater than the number
of processors, we output "Pigzj: resource unavailable (Pigzj.java:error:create)." Note: 
this output matches that of the error message from pigz. Else, we can set the number of
processors to be the "number". We use ArrayIndexOutOfBoundsException to print the error
message indicating the number of processors was not correctly specified. We use the 
NumberFormatException to print the error message indicating the number of processors was
not an integer. Both of these exit with a number not equal to 0. If "-p" was not used,
the arguments were invalid and we exit incorrectly again.

Next we reset our CRC32 value and begin implementation. I first tried to create a queue
for the tasks in a way that corresponds to the threadpool and the number of threads 
that were from the input. The idea was that tasks could be given to different threads. 
Each thread would execute their task, then go back to sleep and wait to be utilized 
again. To do this, I initialized an executor with the number of processors we specified. 
Note: I imported java.util.concurrent.Callable,Executors,ExecutorService, and Future to
aid in the implementation. I created a threadpool with the method:
 newFixedThreadPool from ExecutorService, and sent it the number of processors. Future 
helped to implement the array list.

Next, I sent the input to create a new BufferedInputStream and used some code from the 
starter code provided to create new bytes. These were buffers for input blocks, 
compressed bocks, and dictionaries, hence why the size is that of the block and 
dictionary. I didn't need a compressed block buffer because my CompressThread method 
creates the actual compression and is called later. I also have a variable that holds 
the size of the input file for my crc that is later used. I then created a for loop that is
supposed to return the number of blocks read. I initialized a variable counter, which was
the byte counter. The file stream is read in and split up into their 128kb to accomodate
for the buffer size. We ensure to update the crc and assign the length of the byte buffer
to the total size. 
The callable and future concurrents that were imported was used to call my CompressThread
method to create the compressed block buffer. 

CompressThread essentially uses the Deflater java import and its DEFAULT_COMPRESSION
method. I then created a new byte buffer that was the size of the block size. 
I set the input of the deflater to be the bytes that were inputted. This corresponds
to the byte_buffer that was sent from the main method. If the length of the dict_buffer
that was sent in was greater than zero, then we could set the value of the dictionary
of the deflater (named compressed) to be the dict_buffer. We then initialized the 
length of the deflater to be zero and set up another if statement. If the length of the 
byte_buffer is less than the size of compression block (128*1024), we are at the last
block and therefore can call the finish method from the Deflater, as well as set the
length by sending the deflate method Deflater.NO_FLUSH. Else, we need to sync the flush 
and set the length with Deflater.SYNC_FLUSH. Finally, we can trim the buffer to the 
appropriate size by creating an updated buffer bite with the size of the new compressed
length and return it. We can send this current callable to the executor to create the 
future one (submit), to be added to our array list. Essentially, we are feeding the 128kb from
the stream to our executor and keeping track of them in the array. We use the byte counter
in a way so that if it is greater than 0, we need to update our crc and totalSize and also
finish the stream with any remaining bytes after we finish. Finally, when all the stream
has been used, we can retrieve the result. We shut down the executor, call our write 
header function, and then iterate through our "future" list. We call future bytes "next."
While iterating through the list of tasks, we have a try/catch block for exceptions. 
We try to write each of the compressed bytes returned from the threads to the file and if 
we catch an IOException, we return the appropriate error message. Finally, we can write
our trailer. 




One error in my code is that running the command "java Pigzj </dev/zero >/dev/full"
causes my program to hang and I get the error message "Could not flush log: stdout 
(No space left on device (28))
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space". When run in
the /usr/local/cs/src/pigz directory, the "pigz </dev/zero >/dev/full" command outputted
"pigz: abort: write error on <stdout> (No space left on device)"

"java Pigzj -p 10000000 </dev/zero >/dev/null" outputs:
Pigzj: resource unavailable (Pigzj.java:error:create), similarly to pigz which, with the
command "pigz -p 10000000 </dev/zero >/dev/null", outputs:
 "pigz: resource unavailable (pigz.c:2207:create)"
 
 
Below is the output when the input has no arguments in the command line:

RUN1)
time gzip <$input >gzip.gz

real	0m7.830s
user	0m7.305s
sys	0m0.057s

time pigz <$input >pigz.gz

real	0m2.556s
user	0m7.122s
sys	0m0.031s

time java Pigzj <$input >Pigzj.gz

real	0m2.836s
user	0m7.296s
sys	0m0.266s

ls -l gzip.gz pigz.gz Pigzj.gz
-rw-r--r-- 1 estee csugrad 43136275 May  6 19:25 Pigzj.gz
-rw-r--r-- 1 estee csugrad 43261332 May  6 19:25 gzip.gz
-rw-r--r-- 1 estee csugrad 43134815 May  6 19:25 pigz.gz

RUN2)
time gzip <$input >gzip.gz

real	0m7.582s
user	0m7.312s
sys	0m0.060s

time pigz <$input >pigz.gz

real	0m2.634s
user	0m7.076s
sys	0m0.048s

time java Pigzj <$input >Pigzj.gz

real	0m2.846s
user	0m7.231s
sys	0m0.315s

ls -l gzip.gz pigz.gz Pigzj.gz
-rw-r--r-- 1 estee csugrad 43136275 May  6 19:34 Pigzj.gz
-rw-r--r-- 1 estee csugrad 43261332 May  6 19:34 gzip.gz
-rw-r--r-- 1 estee csugrad 43134815 May  6 19:34 pigz.gz

RUN3)
time gzip <$input >gzip.gz

real	0m8.040s
user	0m7.314s
sys	0m0.080s

time pigz <$input >pigz.gz

real	0m2.514s
user	0m7.139s
sys	0m0.035s

time java Pigzj <$input >Pigzj.gz

real	0m2.701s
user	0m7.298s
sys	0m0.324s

ls -l gzip.gz pigz.gz Pigzj.gz
-rw-r--r-- 1 estee csugrad 43136275 May  6 19:36 Pigzj.gz
-rw-r--r-- 1 estee csugrad 43261332 May  6 19:35 gzip.gz
-rw-r--r-- 1 estee csugrad 43134815 May  6 19:36 pigz.gz

RUN4)
time gzip <$input >gzip.gz

real	0m7.763s
user	0m7.308s
sys	0m0.060s

time pigz <$input >pigz.gz

real	0m3.999s
user	0m7.085s
sys	0m0.033s

time java Pigzj <$input >Pigzj.gz

real	0m3.601s
user	0m7.239s
sys	0m0.188s

ls -l gzip.gz pigz.gz Pigzj.gz
-rw-r--r-- 1 estee csugrad 43136275 May  9 09:37 Pigzj.gz
-rw-r--r-- 1 estee csugrad 43261332 May  9 09:37 gzip.gz
-rw-r--r-- 1 estee csugrad 43134815 May  9 09:37 pigz.gz


Compression ratio
file size: 125942959
with gzip: 43261332
with pigz: 43134815
with Pigzj: 43136275
gzip compression ratio: 2.91121
pigz compression ratio: 2.91975
Pigz compression ratio: 2.91965


pigz and Pigzj had identical output and Pigzj was slightly slower for the real
and user time than pigz, but sys value was faster. The compression ratio of Pigz
compared to pigz was very similar, with Pigz being slightly lower.

The command "pigz -d <Pigzj.gz | cmp - $input" outputted nothing as expected


With -p 6, 100, 100000, 1
Note: When input processors is greater than processors available, there is also 
the output line:
Pigzj: resource unavailable (Pigzj.java:error:create)

RUN1)


time pigz -p 6 <$input >pigz.gz

real	0m4.685s
user	0m7.088s
sys	0m0.075s

time java Pigzj -p 6 <$input >Pigzj.gz

real	0m2.545s
user	0m7.224s
sys	0m0.212s


RUN2)

time pigz -p 100 <$input >pigz.gz

real	0m2.646s
user	0m7.109s
sys	0m0.146s


time java Pigzj -p 100 <$input >Pigzj.gz

real	0m2.952s
user	0m7.285s
sys	0m0.195s

RUN3)

time pigz -p 100000 <$input >pigz.gz

real	0m2.836s
user	0m7.215s
sys	0m0.466s

time java Pigzj -p 100000 <$input >Pigzj.gz

real	0m2.646s
user	0m7.226s
sys	0m0.224s

RUN4)
time pigz -p 1 <$input >pigz.gz

real	0m7.928s
user	0m6.975s
sys	0m0.055s

time java Pigzj -p 1 <$input >Pigzj.gz

real	0m7.454s
user	0m7.169s
sys	0m0.245s


ls -l pigz.gz Pigzj.gz $input

-rw-r--r-- 1 eggert csfac   125942959 Mar 26 11:20 /usr/local/cs/jdk-16.0.1/lib/modules
-rw-r--r-- 1 estee  csugrad  43136275 May  9 11:57 Pigzj.gz
-rw-r--r-- 1 estee  csugrad  43134815 May  9 11:57 pigz.gz


-p had identical output to pigz. We would expect methods to work better in C, and 
this can be seen in the comparison of times between the two. However, when running with 
the "-p", Pigzj's user time was always only slighter slower, but it's real time was 
sometimes faster, and sometimes slower.


Per the specs, I ran strace to generate traces of system calls. Pigzj has a larger
trace that gzip and pigz. It appeared as though their running time was mostly for
reading the files, whereas Pigzj's time was mostly for navigating through memory.

Because of the threads that need to be taken care of from libraries' overhead, when
I tested my code with small files, its performance decreased and it ran slower than gzip.
From testing with various file sizes, I saw that the performance increased as the
file size increased. This is the main benefit of parallelism. The real speed increases 
as number of processors increases to a limit, from what I observed. This limit is some
threshold which seems to be when the threads are not able to speed up the processes 
anymore.

From my tests, it would appear that my Pigzj compression works best for large sized 
inputs as there are more processors. At the point where there is max functionality of
the threads, there is no additional speed benefit as now, the threads have to wait for
other threads in my array to finish their responsibilities. Reducing copying from arrays
could help speed up the process, though I am not sure how to fully implement this yet.



