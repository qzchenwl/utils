function id_csum(idnum)
{
    var workarr = idnum.split('').reverse();
    function W(i) {
        return Math.pow(2, i-1)%11;
    }
    function S() {
        var sum = 0;
        for(var j=0; j<17; ++j) {
            sum += workarr[j]*W(j+2);
        }
        return sum;
    }
    return (12-(S()%11))%11;
}
