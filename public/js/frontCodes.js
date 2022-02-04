class FrontCodes {
    static textRandom = 'Clique para gerar um drink aleatório';
    static pathLoadingGif = '../public/images/loading.gif';

    static listaItens(itens){
        let ul = document.getElementById('listaDrink');
        itens.forEach((item) => {
            let link = document.createElement('a');
            let li = document.createElement('li');
            li.setAttribute('id', item.idDrink);
            link.appendChild(document.createTextNode(item.strDrink));
            li.appendChild(link);
            ul.appendChild(li);
        });
    }

    static setLoadingRandom(){
        let cardRandom = document.getElementById('drinkAleatorio');
        cardRandom.style.pointerEvents = 'none';
        cardRandom.innerHTML = '';
        let link = document.createElement('img')
        link.setAttribute('src', this.pathLoadingGif);
        cardRandom.appendChild(link);
    }

    static setRandomText(){
        let cardRandom = document.getElementById('drinkAleatorio');
        cardRandom.style.pointerEvents = 'all';
        cardRandom.innerHTML = '';
        let text = document.createElement('h2');
        text.appendChild(document.createTextNode(this.textRandom));
        cardRandom.appendChild(text);
    }
}