class FrontCodes {
    static textRandom = 'Clique para gerar um drink aleatório';
    static URL_ROOT = location.href.substring(0, location.href.lastIndexOf('/') + 1);
    static pathLoadingGif = `${this.URL_ROOT}public/images/drink_loader.gif`;

    static listaItens(itens) {
        let ul = document.getElementsByClassName('drinksList')[0].children[0];
        this.removeChildren(ul);
        
        itens.forEach((item) => {
            let card = document.createElement('a');
            card.setAttribute('class', 'card');
            card.setAttribute('href', `${this.URL_ROOT}public/view/visualizar.html?${item.idDrink}`)

            let cardHeader = document.createElement('div');
            cardHeader.setAttribute('class', 'card-header');
            cardHeader.appendChild(document.createTextNode(item.strDrink));

            let cardBody = document.createElement('div');
            cardBody.setAttribute('class', 'card-body');
            let img = document.createElement('img');
            img.setAttribute('src', item.strDrinkThumb);
            img.setAttribute('loading', 'lazy');
            cardBody.appendChild(img);

            let cardFooter = document.createElement('div');
            cardFooter.setAttribute('class', 'card-footer');
            let itemSummary = document.createElement('p');
            itemSummary.setAttribute('class', 'description');
            itemSummary.appendChild(document.createTextNode(item.strInstructions));
            cardFooter.appendChild(itemSummary);

            card.appendChild(cardHeader);
            card.appendChild(cardBody);
            card.appendChild(cardFooter);

            let carousel = document.getElementsByClassName('drinksList')[0].children[0];
            carousel.appendChild(card);
        });
    }

    static setLoadingRandom() {
        let cardRandom = document.getElementById('drinkAleatorio');
        cardRandom.style.pointerEvents = 'none';
        cardRandom.innerHTML = '';
        let link = document.createElement('img')
        link.setAttribute('src', this.pathLoadingGif);
        cardRandom.appendChild(link);
    }

    static setRandomText() {
        let cardRandom = document.getElementById('drinkAleatorio');
        cardRandom.style.pointerEvents = 'all';
        cardRandom.innerHTML = '';
        let text = document.createElement('h2');
        text.appendChild(document.createTextNode(this.textRandom));
        cardRandom.appendChild(text);
    }

    static removeChildren(nodeParent) {
        while (nodeParent.hasChildNodes()) {
            nodeParent.removeChild(nodeParent.lastChild);
        }
    }
}