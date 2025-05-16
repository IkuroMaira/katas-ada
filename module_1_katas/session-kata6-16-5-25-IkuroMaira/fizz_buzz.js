// FIZZ BUZZ
// Écris une fonction `fizzBuzz()` qui prend en paramètre un nombre `n`.
//
// La fonction doit retourner un tableau de chaînes de caractères `answer` (indexé à partir de 1).
//
// Voici les règles pour remplir ce tableau :
//
// - `answer[i] == "FizzBuzz"` si `i`est divisible par `3` ET`5`.
// - `answer[i] == "Fizz"` si `i`est divisible uniquement par `3`.
// - `answer[i] == "Buzz"` si `i`est divisible uniquement par `5`.
// - `answer[i] == i`si aucune des conditions précédentes n’est vraie.
//
// Le tableau fait la taille donnée par le nombre `n` donné en paramètre de la fonction.

function fizzBuzz(n) {
    console.log("Taille du tableau: ", n);
    const answer = [];

    for (let i = 1; i <= n; i++) {
        if (i % 3 === 0 && i % 5 === 0) {
            answer.push("FizzBuzz");
        } else if (i % 3 === 0) {
            answer.push("Fizz");
        } else if (i % 5 === 0) {
            answer.push("Buzz");
        } else {
            let string = i.toString();
            answer.push(string);
        }
    }

    console.log(answer)
    return answer
}

fizzBuzz(3);
// retourne ["1", "2", "Fizz"]

fizzBuzz(5);
// retourne ["1", "2", "Fizz", "4", "Buzz"]

fizzBuzz(15);
// retourne
// ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "FizzBuzz"]