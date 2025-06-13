// MOYENNE
let arrayNumbers = [];
let total = 0;

function addNumbers(num) {
    arrayNumbers.push(parseInt(num));
    total += num;
    return "Le total = " + total;
}

function getAverage() {
    let moyenne = total / arrayNumbers.length;
    return "La moyenne = " + moyenne;
}

// MÉDIANNE

let arrayNumbersMedian = [];
let totalMedian = 0;

function stockNumbers(num) {
    arrayNumbersMedian.push(parseInt(num));
    totalMedian += num;
    return totalMedian;
}

function getMedian() {
    let arraySort =  arrayNumbersMedian.sort(function(a, b) {
        return a - b;
    });

    let rang = (arrayNumbersMedian.length + 1) / 2

    if (arrayNumbersMedian.length % 2 === 0) {
        console.log((arraySort[(arrayNumbersMedian.length / 2) - 1] + arraySort[arrayNumbersMedian.length / 2]) / 2);
        let medianne = (arraySort[rang-1.5] + arraySort[rang-0.5]) / 2;
        return "La médianne = " + medianne
    } else {
        return "La médianne = " + arraySort[rang-1];
    }
}

console.log("---MOYENNE---");

addNumbers(2);
addNumbers(10);

console.log(getAverage());

// stockNumbers(54);
// stockNumbers(59);
// stockNumbers(65);

// stockNumbers(70)
// stockNumbers(84)
// stockNumbers(66)

stockNumbers(4)
stockNumbers(1)
stockNumbers(9)
stockNumbers(10)

console.log("---MEDIANNE---");

console.log(getMedian());