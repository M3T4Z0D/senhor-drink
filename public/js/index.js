window.onload = function () {
    listenerRandomDrink();
    listenerSearchDrinkByName();
};

function listenerRandomDrink() {
    let botao = document.getElementById('drinkAleatorio');

    botao.onclick = async function () {
        event.preventDefault();
        let drink = await Connections.getRandomDrink();
        FrontCodes.listaItens(drink);
    };
}

function listenerSearchDrinkByName() {
    let botao = document.getElementById('searchDrink');

    botao.addEventListener('click', async function () {
        event.preventDefault();
        let drinkName = document.getElementById('drinkSearch').value;
        let drinks = await Connections.getDrinksByName(drinkName);
        FrontCodes.listaItens(drinks);
    });
}