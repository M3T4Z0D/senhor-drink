class Helpers {
    
    static standardize(str) {
        str = str.toUpperCase().trim();

        str = str.replace(/[ÃÁÀ]/g, "A");
        str = str.replace(/[ÈÉÊË]/g, "E");
        str = str.replace(/[ÓÒÕ]/g, "O");
        str = str.replace(/[ÍÌ]/g, "I");
        str = str.replace(/[ÚÙ]/g, "U")

        return str.toLowerCase();
    }
}