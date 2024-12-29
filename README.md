The project processes a photo of 256 by 256 image with 24BPP.  
In the ./ROM_init folder are three mif files of lena.raw with Gaussian noise added, that will be loaded onto the three ROMs.  
The project expects the mif files to be 512 deep and 1024 wide HEX format for both addresses and data, Such that each address contains exactly half a row of the image of one color type.  
After the project runs it is expected to finish in around 60 us and have ready at the RAMs for reading.  
Finally I've attached some python scripts to do some converting:  
*from mem to mif.  
*from 3 mif files to raw.  
*from raw to 3 mif files.  
*noise adder for adding to a 256 by 256 Gaussian noise.  
