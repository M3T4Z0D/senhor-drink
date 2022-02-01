// THE COCKTAIL DB https://thecocktaildb.com/api.php

//const URL_DRINK_RANDOM = "www.thecocktaildb.com/api/json/v1/1/random.php";

window.onload = function(){
    listenerRandomDrink();
};

function listenerRandomDrink(){
    let botao = document.getElementById('drinkAleatorio');

    botao.onclick = async function(){
        event.preventDefault();
        let drink = await getRandomDrink();
        console.log(drink);
    };
}

async function getRandomDrink(){
    let response = await fetch('https://www.thecocktaildb.com/api/json/v1/1/random.php');
    let data = await response.json();

    return data;
}