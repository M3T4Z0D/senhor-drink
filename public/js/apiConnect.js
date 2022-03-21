// THE COCKTAIL DB https://thecocktaildb.com/api.php

class Connections {
    static async getRandomDrink() {
        let response = await fetch(`https://www.thecocktaildb.com/api/json/v1/1/random.php`);
        let data = await response.json();

        return data.drinks;
    }

    static async getDrinksByName(name) {
        let response = await fetch(`https://www.thecocktaildb.com/api/json/v1/1/search.php?s=${name}`);
        let data = await response.json();

        return data.drinks;
    }

    static async getDrinkById(id) {
        let response = await fetch(`https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=${id}`);
        let data = await response.json();

        return data.drinks;
    }

    static error(errorCode) {
        let errorUrl = (`https://http.cat/${errorCode.toString()}.jpg`);

        return errorUrl;
    }
}