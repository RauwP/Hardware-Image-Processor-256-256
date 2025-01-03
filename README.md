Overview:  
The project processes a photo of 256 by 256 image with 24BPP.  
In the ./ROM_init folder are three mif files of lena.raw with Gaussian noise added, that will be loaded onto the three ROMs.  
The project expects the mif files to be 512 deep and 1024 wide HEX format for both addresses and data, Such that each address contains exactly half a row of the image of one color type.  
After the project runs it is expected to finish in around 60 us and have ready at the RAMs for reading.  
Finally I've attached some python scripts to do some converting:  
*from mem to mif.  
*from 3 mif files to raw.  
*from raw to 3 mif files.  
*noise adder for adding to a 256 by 256 image Gaussian noise.  
  
Technical Info:  
Clock max frequency: 50MHz.  
This project is designed for cyclone IV E EP4CE115F29C7.  
For the actual processing of the noise I used a 3*3 median of the medians of the columns.  
The main limitation of this project was the amount of combinatorical logic units, to get around this I sacrificed accuracy for both speed and hardware efficiency, and used median of medians instead of better alternatives.   
To change the image for processing ypu need to create and include the mif files in the project and change the mif_path attribute of the ROM to fit the desired path.  
Block Diagram:  
![Block Diagram](https://github.com/user-attachments/assets/8014c5e8-150c-47bd-ad13-c3a1a094323c)  
  
Usage Examples:  
![petruha before and after](https://github.com/user-attachments/assets/6f20ae0a-3a63-4fe0-8196-4db9750a91e0)  
![lena before and after](https://github.com/user-attachments/assets/17ee3b82-5133-4827-821d-8f7994c7d63d)  
