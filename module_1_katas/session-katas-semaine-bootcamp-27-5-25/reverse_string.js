function reverseString(string) {
    let split = string.split(" ").reverse();
    let toString = split.join(" ");
    console.log(toString);
    return toString;
}

function reverseStringWithout(string) {
    let word = "";
    let array = [];
    let reverseArray = [];
    let final = "";

    for (let i = 0; i <= string.length; i++) {
        if (string[i] === " ") {
            array.push(word);
            word = "";
        } else if (i == string.length) {
            array.push(word);
            word = "";
        } else {
            word += string[i];
        }
    }

    for (let i = array.length - 1; i >= 0; i--) {
        reverseArray.push(array[i]);
    }

    for (let i = 0; i < reverseArray.length; i++) {
        final += reverseArray[i] + " ";
    }

    console.log(final);
    return final;
}

reverseString("On veut une fonction qui inverse cette chaîne de caractères");
console.log("------------------------")
reverseStringWithout("On veut une fonction qui inverse cette chaîne de caractères");
