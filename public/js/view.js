var drinkGlobal;
window.onload = async function () {
    //TO-DO
    showDrink();
}

async function showDrink() {
    let searchParams = getSearchParameters();

    if (searchParams == null) {
        showError('404');
        return;
    }

    searchParams = searchParams.split('?')[1];

    let drink = await Connections.getDrinkById(searchParams);

    drink = drink[0];
    defineWindowTitle(drink.strDrink);

    document.getElementById('nomeDrink').textContent = drink.strDrink;
}

function getSearchParameters() {
    let parameters = window.location.search;

    return parameters != '' ? parameters : null;
}

async function showError(errorCode) {
    document.body.style.display = 'flex';
    document.body.style.backgroundColor = 'black';

    let imgError = document.createElement('img');
    imgError.setAttribute('src', Connections.error(errorCode));
    imgError.style.margin = 'auto';

    document.body.appendChild(imgError)
    return;
}

function defineWindowTitle(name){
    document.title = name;
}