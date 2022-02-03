class FrontCodes {

    static listaItens(itens){
        let ul = document.getElementById('listaDrink');
        itens.forEach((item) => {
            let link = document.createElement('a');
            let li = document.createElement('li');
            li.setAttribute('id', item.idDrink);
            link.setAttribute('href', window.location.origin + '/visualizar?id=' + item.idDrink);            
            link.appendChild(document.createTextNode(item.strDrink));
            li.appendChild(link);
            ul.appendChild(li);

            console.log(link, li, ul);
        });
    }
}