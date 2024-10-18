         
         terraform

pokiapi And Amazon DynamoDB - in terraform.

1. In this exercise we will use pokeapi website to collect Pokémon's.

2. Our Pokémon collection will be saved in DynamoDB

3. You need to design your data schema, and what attributes you want to save in the DB. (n e mandatory)

4. The flow of your program will be:
   
  a. Ask the user if he would like to draw a Pokémon
  
  b. If yes was entered:

  i. A list of Pokémon's will be downloaded, and a random Pokémon will be
    
  chosen.

  ii. If the Pokémon name is already in our DB

  1. extract its details and present nicely to user

  iii. Else

  1. Download the details, save to DB, present nicely to user

  c. Else

  i. Give a farewell greeting to the user and exit

  d. Return to a.

5. Create automatic deployment for your app
  
  a. Your script should include

  i. Infrastructure provisioning ( including server and any other security networking needed)

  ii. Schema creation script ( creating tables on DynamoDB )
  
  ii. Install the app which is located in GITHUB in your server )
 
  iii. Set Up Automatic Startup on VM ( bashrc. )

6. Upload your project to Github with appropriate Readme file
  * provide besides your solution the link of your project in github
  https://pokeapi.co/
