// 🚪 **Parenthèses valides**
//
// Écris une fonction `isValid()` qui prend en paramètre une chaîne de caractère `str` contenant uniquement les caractères `'('`, `')'`, `'{'`, `'}'`, `'['` et `']'`, et qui retourne si cette chaîne est **valide** ou non.
//
// Une chaîne est considérée comme valide si elle respecte **toutes les règles suivantes** :
//
// 1. Les parenthèses ouvrantes doivent être **fermées par le même type de parenthèse**.
// 2. Les parenthèses doivent être **fermées dans le bon ordre**.
// 3. Chaque parenthèse fermante doit avoir **une parenthèse ouvrante correspondante du même type**.
//
// Pour information, `str` ne contient **que** les caractères : `'('`, `')'`, `'{'`, `'}'`, `'['`, `']'`.

function isValid(str) {
    if (!typeof str === "string") {
        console.log(false);
        return false
    }

    const strArray = str.split("");
    console.log("Premier tableau", strArray);

    const comparArray = [];
    const pairs = {
        ')': '(',
        '}': '{',
        ']': '['
    };

    for (let i = 0; i < strArray.length; i++) {
        comparArray.push(strArray[i]);
        // console.log(strArray[i]);
    }

    for (let i = 1; i < strArray.length; i++) {
        if (!strArray[i-1] === comparArray[i]) {
            console.log(false);
            return false;
        }
    }

    console.log(true);
    return true
}

const str = "()"
isValid(str);
// retourne `true`

const str1 = "()[]{}"
isValid(str1);
// retourne `true`

const str2 = "(]"
isValid(str2);
// retourne `false`

const str3 = "([])"
isValid(str3);
// retourne `true`