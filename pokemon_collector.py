import boto3
import requests
import random
import sys

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='us-west-2')
table = dynamodb.Table('PokemonCollection')

def get_random_pokemon():
    response = requests.get('https://pokeapi.co/api/v2/pokemon?limit=50')
    pokemon_list = response.json()['results']
    return random.choice(pokemon_list)['name']

def get_pokemon_details(name):
    response = requests.get(f'https://pokeapi.co/api/v2/pokemon/{name}')
    data = response.json()
    return {
        'name': name,
        'height': data['height'],
        'weight': data['weight'],
        'types': [t['type']['name'] for t in data['types']],
        'abilities': [a['ability']['name'] for a in data['abilities']]
    }

def save_pokemon(pokemon):
    table.put_item(Item=pokemon)

def get_pokemon_from_db(name):
    response = table.get_item(Key={'name': name})
    return response.get('Item')

def display_pokemon(pokemon):
    print(f"Name: {pokemon['name'].capitalize()}")
    print(f"Height: {pokemon['height']}")
    print(f"Weight: {pokemon['weight']}")
    print(f"Types: {', '.join(pokemon['types'])}")
    print(f"Abilities: {', '.join(pokemon['abilities'])}")

def main():
    while True:
        choice = input("Would you like to draw a Pokémon? (yes/no): ").lower()
        if choice == 'yes':
            pokemon_name = get_random_pokemon()
            pokemon = get_pokemon_from_db(pokemon_name)
            if pokemon:
                print("Pokémon found in our collection!")
            else:
                print("New Pokémon discovered!")
                pokemon = get_pokemon_details(pokemon_name)
                save_pokemon(pokemon)
            display_pokemon(pokemon)
        elif choice == 'no':
            print("Thank you for playing the Pokémon Collector. Goodbye!")
            sys.exit(0)
        else:
            print("Invalid input. Please enter 'yes' or 'no'.")

if __name__ == "__main__":
    main()
