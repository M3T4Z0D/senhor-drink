window.onload = function () {
    preventDefaultInputs();
    scrollToTop();
    listenerRandomDrink();
    listenerSearchDrinkByName();
};

function listenerRandomDrink() {
    let botao = document.getElementById('drinkAleatorio');

    botao.onclick = async function (event) {
        event.preventDefault();
        FrontCodes.setLoadingRandom();
        let drink = await Connections.getRandomDrink();
        FrontCodes.listaItens(drink);
        FrontCodes.setRandomText();
    };
}

function listenerSearchDrinkByName() {
    let botao = document.getElementById('searchDrink');

    botao.addEventListener('click', async function (event) {
        event.preventDefault();

        let drinkName = Helpers.standardize(document.getElementById('drinkSearch').value);
        let drinks = await Connections.getDrinksByName(drinkName);

        FrontCodes.listaItens(drinks);
    });
}

function scrollToTop() {

    let button = document.getElementById('scrollToTopButton');

    button.addEventListener('click', function () {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });

        document.getElementsByClassName('main-card')[0].focus();
    })
}

function preventDefaultInputs() {
    let inputs = document.querySelectorAll('input');

    inputs.forEach(input => {
        input.addEventListener('keyup', function (event) {
            event.preventDefault();
        })
    })
}