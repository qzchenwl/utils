public class Fraction {
    
    private int num;
    private int der;
    
    Fraction(int num) {
        this.num = num;
        this.der = 1;
    }
    Fraction(int num, int der) {
        this.num = num;
        this.der = der;
    }
    
    Fraction plus(Fraction rh) throws Exception {
        int DER = this.der * rh.valueOfDer();
        int NUM = this.num * rh.valueOfDer() + rh.valueOfNum() * this.der;
        
        if(DER == 0)
            throw new Exception();
        
        return new Fraction(NUM, DER);
        
    }
    
    Fraction minus(Fraction rh) throws Exception {
        int DER = this.der * rh.valueOfDer();
        int NUM = this.num * rh.valueOfDer() - rh.valueOfNum() * this.der;
        
        if(DER == 0)
            throw new Exception();
        
        return new Fraction(NUM, DER);
    }
    
    Fraction multiply(Fraction rh) throws Exception {
        int DER = this.der * rh.valueOfDer();
        int NUM = this.num * rh.valueOfNum();
        
        if(DER == 0)
            throw new Exception();
        
        return new Fraction(NUM, DER);
    }
    
    Fraction der(Fraction rh) throws Exception {
        int DER = this.der * rh.valueOfNum();
        int NUM = this.num * rh.valueOfDer();
        
        if(DER == 0)
            throw new Exception();
        
        return new Fraction(NUM, DER);
    }
    
    int valueOfInt() {
        if(num % der == 0)
            return num/der;
        else return -1;
    }
    
    int valueOfDer() {
        return der;
    }
    int valueOfNum() {
        return num;
    }

}