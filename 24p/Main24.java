public class Main24 {

    /**
     * @param args
     */
    
    static int[][] zuhe = {
        { 0, 1, 2, 3 },
        { 0, 1, 3, 2 },
        { 0, 2, 1, 3 },
        { 0, 2, 3, 1 },
        { 0, 3, 1, 2 },
        { 0, 3, 2, 1 },
        { 1, 0, 2, 3 },
        { 1, 0, 3, 2 },
        { 1, 2, 0, 3 },
        { 1, 2, 3, 0 },
        { 1, 3, 0, 2 },
        { 1, 3, 2, 0 },
        { 2, 0, 1, 3 },
        { 2, 0, 3, 1 },
        { 2, 1, 0, 3 },
        { 2, 1, 3, 0 },
        { 2, 3, 0, 1 },
        { 2, 3, 1, 0 },
        { 3, 0, 1, 2 },
        { 3, 0, 2, 1 },
        { 3, 1, 0, 2 },
        { 3, 1, 2, 0 },
        { 3, 2, 0, 1 },
        { 3, 2, 1, 0 }
    };
    static int[] num = new int[4];
    static int[] op = new int[3];
    static String[] OpStr = { "+", "-", "*", "/" };
    static int[] input = { 8, 5, 4, 1 };
    
    static String[] RESULT = new String[1536];
    static boolean hasResult = false;
    static int count = 0;
    
    public static void main(String[] args) {
        if (args.length != 4) {
            System.out.println("4 numbers needed.");
            return;
        }
        for (int i = 0; i < 4; ++i) {
            input[i] = Integer.parseInt(args[i]);
        }
        analysis();
        print();
    }
    
    static void analysis() {
        init();
        for(int i = 0; i < 24; ++i ) {
            //pailie of number
            num[0] = input[ zuhe[i][0] ];
            num[1] = input[ zuhe[i][1] ];
            num[2] = input[ zuhe[i][2] ];
            num[3] = input[ zuhe[i][3] ];
            
            for (int i2 = 0; i2 < 64; ++i2 ) {
                //pailie of operator
                int val = i2;
                op[2] = val/16;
                val %= 16;
                op[1] = val/4;
                val %= 4;
                op[0] = val;
                
                Fraction a = new Fraction(num[0]);
                Fraction b = new Fraction(num[1]);
                Fraction c = new Fraction(num[2]);
                Fraction d = new Fraction(num[3]);
                Fraction result1, result2, result3, result4, result5;
    
                try {
                //                (    (    (O    X    O)   X     O)   X     O)
                    result1 = expr(expr(expr(a, op[0], b), op[1], c), op[2], d);
                } catch (Exception e) { 
                    result1 = new Fraction(0);
//                    System.out.println("Exception catched in (((OXO)XO)XO) : result1");
                    }
                
                try {
                //                (    (O   X        (O   X     O))   X     O)
                    result2 = expr(expr(a, op[0],expr(b, op[1], c)), op[2], d);
                } catch (Exception e) { 
                    result2 = new Fraction(0); 
//                    System.out.println("Exception catched in ((OX(OXO))XO) : result2");
                    }
                
                try {
                //                (    (O    X    O)    X        (O   X     O))
                    result3 = expr(expr(a, op[0], b), op[1], expr(c, op[2], d));
                } catch (Exception e) { 
                    result3 = new Fraction(0);
//                    System.out.println("Exception catched in ((OXO)X(OXO)) : result3");
                    }
                
                try {
                //                  (O    X        (O    X        (O   X     O)))
                    result4 = expr(a, op[0], expr(b, op[1], expr(c, op[2], d)));
                } catch (Exception e) { 
                    result4 = new Fraction(0);
//                    System.out.println("Exception catched in (OX(OX(OXO))) : result4");
                    }
                
                try {
                //                (O   X         (    (O   X     O)   X     O))
                    result5 = expr(a, op[0], expr(expr(b, op[1], c), op[2], d));
                } catch (Exception e) { 
                    result5 = new Fraction(0);
//                    System.out.println("Exception catched in (OX((OXO)XO)) : result5");
                    }
                
                if(result1.valueOfInt() == 24) {
                    RESULT[count++] = new String("(((" + num[0] + OpStr[op[0]] + num[1]+")" + OpStr[op[1]] + num[2] + ")" +OpStr[op[2]] + num[3] +")");
//                    System.out.println( RESULT[count -1] );
                }
                else if(result2.valueOfInt() == 24) {
                    RESULT[count++] = new String("((" + num[0] + OpStr[op[0]] + "("+ num[1] + OpStr[op[1]] + num[2] +"))" +  OpStr[op[2]] + num[3] + ")");
//                    System.out.println(RESULT[count-1]);
                }
                else if(result3.valueOfInt() == 24) {
                    RESULT[count++] = new String("((" + num[0] + OpStr[op[0]] + num[1] +")" + OpStr[op[1]] +"("+ num[2]  +  OpStr[op[2]] + num[3] + "))");
//                    System.out.println(RESULT[count-1]);
                }
                else if(result4.valueOfInt() == 24) {
                    RESULT[count++] = new String("(" + num[0] + OpStr[op[0]] + "("+ num[1] + OpStr[op[1]] +"("+ num[2]  +  OpStr[op[2]] + num[3] + ")))");
//                    System.out.println(RESULT[count-1]);
                }
                else if(result5.valueOfInt() == 24) {
                    RESULT[count++] = new String("(" + num[0] + OpStr[op[0]] + "(("+ num[1] + OpStr[op[1]] + num[2]  + ")"+  OpStr[op[2]] + num[3] + "))");
//                    System.out.println(RESULT[count-1]);
                }
                
            }
        }
        count = 0;
    }
    
    static Fraction expr(Fraction lh, int op, Fraction rh) throws Exception {
        Fraction result = new Fraction(-1);
        switch(op) {
        case 0: // +
            result = lh.plus(rh);
            break;
        case 1: // -
            result = lh.minus(rh);
            break;
        case 2: // *
            result = lh.multiply(rh);
            break;
        case 3: // /
            result = lh.der(rh);
            break;
            default: 
                result = null;
        }
        return result;
    }
    
    static void init() {
        int i = 0;
        while(RESULT[i] != null) {
            RESULT[i] = null;
//            System.out.println("set RESULT["+i+"] null");
            ++i;
        }
    }
    
    static void print() {
        int i = 0;
        if(RESULT[0] == null) 
            System.out.println("no solution!");
        while(RESULT[i] != null) {
            System.out.println(RESULT[i]);
            ++i;
        }
    }

}
