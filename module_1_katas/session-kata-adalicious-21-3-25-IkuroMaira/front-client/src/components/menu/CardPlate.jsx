import React from "react";
import styles from './CardPlate.module.css';

export default function CardPlate({ plate }) {
    return (
        <>
            <div className={styles.platCard}>
                <img className={styles.platImage} src={plate.image} alt="Nom du plat"/>
                <div className={styles.platInfos}>
                    <h1 className={styles.platTitle}>{plate.name}</h1>
                    <p className={styles.platDescription}>{plate.description}</p>
                    <button className={styles.btnOrder}>Commander</button>
                </div>
            </div>
        </>
    )
}