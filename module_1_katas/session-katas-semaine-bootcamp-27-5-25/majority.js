function majority(array) {
    let compteur = 1;

    for (let i = 0; i < array.length; i++) {
        for (let j = i; j < array.length ; j++) {
            if (array[i] === array[j+1]) {
                compteur += 1;
                console.log("array[i]", array[i]);
                console.log("array[j]", array[j+1]);
            }
        }
    }

    console.log(compteur);
}

majority([3,1,4,1,4,1]);
// majority([33,44,55,66,77])
// majority([1,2,3,4])

// Préparer son setup avant un entretien
// 1- Regarder d'abord ce que prend comme argument la fonction
// 2- On commence par là cas le plus facile (on n'est pas là pour souffrir)
// 3- On peut essayer de visualiser les différentes variables et données nécessaires
// 4- Commencer à développer un petit algo pour avoir nos premières lignes de code

// On voit que dans le premier cas, je vais devoir compter un nombre de nombre