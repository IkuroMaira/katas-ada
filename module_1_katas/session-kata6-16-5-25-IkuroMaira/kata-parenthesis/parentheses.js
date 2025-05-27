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
    if (typeof str !== "string") {
        console.log(false);
        return false;
    }

    if (str.length % 2 !== 0) {
        console.log(false)
        return false;
    }

    const stack = [];

    // Map des correspondances : fermante -> ouvrante
    const pairs = {
        ')': '(',
        '}': '{',
        ']': '['
    };

    for (let i = 0; i < str.length; i++) {
        const char = str[i];

        if (char === '(' || char === '{' || char === '[') {
            stack.push(char);
        }
        else if (char === ')' || char === '}' || char === ']') {
            const lastOpening = stack.pop();

            if (lastOpening !== pairs[char]) {
                console.log(false)
                return false;
            }
        }
    }

    console.log(stack.length === 0);
    return stack.length === 0;
}

// Tests
console.log("Test 1 - '()' :", isValid("()"));           // true
console.log("Test 2 - '()[]{}':", isValid("()[]{}")); // true
console.log("Test 3 - '(]' :", isValid("(]"));          // false
console.log("Test 4 - '([])' :", isValid("([])"));      // true
console.log("Test 5 - '(((' :", isValid("((("));        // false
console.log("Test 6 - ')))' :", isValid(")))"));        // false
