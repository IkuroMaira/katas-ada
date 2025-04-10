import React, { useState } from "react";
import styles from './CardPlate.module.css';
import { useNavigate } from "react-router-dom";

export default function CardPlate({ plate }) {
    const navigate = useNavigate();

    const handleSubmit = (event) => {
        event.preventDefault();

        // Récupérer l'ID du plat du serveur
        const idPlate = plate.id;

        // Envoyer l'id sur la page Menu
        if (!isNaN(idPlate)) {
            console.log("ID du plat", idPlate);
            navigate('/menu', { state: { idPlate } })
            // TODO: Envoyer l'id dans la table orders
        } else {
            const errorMessage= "Veuillez choisir un plat.";
            console.log("L'id n'est pas valide !")
        }
    }

    return (
        <>
            <div className={styles.plateCard}>
                <img className={styles.plateImage} src={plate.image} alt={plate.name}/>

                <div className={styles.plateInfos}>
                    <h1 className={styles.plateTitle}>{plate.name}</h1>

                    <p className={styles.plateDescription}>{plate.description}</p>

                    <p className={styles.platePrice}>{plate.price}€</p>

                    <button type='submit' className={styles.btnOrder} onClick={handleSubmit}>Commander</button>
                </div>
            </div>
        </>
    )
}