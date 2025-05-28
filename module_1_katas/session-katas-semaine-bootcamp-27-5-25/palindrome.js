function palindrome(number) {
    console.log("---TEST---");
    // console.log(number);

    const string = number.toString()
    // console.log(string);
    // console.log(typeof(string));

    const split = string.split("");
    // console.log(split);

    const reverseString = split.reverse();
    // console.log(reverseString);

    for (let i = 0; i < string.length; i++) {
        if (string[i] === reverseString[i]) {
            console.log("OK");
        } else {
            console.log(false)
            return false
        }
    }

    console.log(true)
    return true
}

palindrome(121);
palindrome(-121);
palindrome(10);
palindrome(1321);

// function palindrome(number) {
//     console.log("---TEST---");
//     // console.log(number);
//
//     const string = number.toString()
//     // console.log(string);
//     // console.log(typeof(string));
//
//     const split = string.split("");
//     console.log(split);
//
//     const reverseString = split.reverse();
//     console.log(reverseString);
//
//     const array = reverseString.join("");
//     console.log(array);
//
//     if (string === array) {
//         console.log(true);
//         return true;
//     } else {
//         console.log(false);
//         return false;
//     }
// }
//
// palindrome(121);
// palindrome(-121);
// palindrome(10);