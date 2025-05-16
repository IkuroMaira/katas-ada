// TWO SUM
// Tu as une liste de nombres appelée `number` (par exemple : `[2, 7, 11, 15]`) et un nombre cible appelé `target` (par exemple : `9`).
//
// Écris une function `twoSum()` qui permet de **retrouver deux nombres dans la liste qui, une fois additionnés, donnent exactement le total `target`**.
//
// Les règles à respecter :
//
// - La fonction doit **retourner les *positions* (ou indices)** de ces deux nombres dans un tableau (et pas les nombres eux-mêmes).
// - Tu ne peux **pas utiliser deux fois le même nombre** (c’est-à-dire que tu ne peux pas prendre deux fois l’indice d’un même élément).
// - Tu peux **rendre les indices dans n'importe quel ordre**.


const numbers = [2, 7, 11, 15];
const target = 9;

function twoSum(numbersEntry, targetEntry) {
    for (let i = 0; i < numbersEntry.length; i++) {
        for (let j = i + 1; j < numbersEntry.length; j++) {
            const sum = numbersEntry[i] + numbersEntry[j]

            if (sum === targetEntry) {
                console.log(`J'ai atteint ma cible ! ${numbersEntry[i]} + ${numbersEntry[j]} = ${sum}`);
                console.log(`Target: ${targetEntry}`);

                console.log([i, j])
                return [i, j];
            }
        }
    }
}

twoSum(numbers, target);
// retourne [0, 1]
// Explication : 2 (à l’indice 0) + 7 (à l’indice 1) = 9


// Exemple 2
const numbers1 = [3, 2, 4]
const target1 = 6
twoSum(numbers1, target1);
// retourne [1, 2]


// Exemple 3
const numbers2 = [3, 3]
const target2 = 6
twoSum(numbers2, target2);
// retourne [0, 1]