import React from "react";
import styles from './CardPlate.module.css';

export default function CardPlate({ plate }) {
    return (
        <>
            <div className={styles.plateCard}>
                <img className={styles.plateImage} src={plate.image} alt={plate.name}/>
                <div className={styles.plateInfos}>
                    <h1 className={styles.plateTitle}>{plate.name}</h1>
                    <p className={styles.plateDescription}>{plate.description}</p>
                    <p className={styles.platePrice}>{plate.price}€</p>
                    <button className={styles.btnOrder}>Commander</button>
                </div>
            </div>
        </>
    )
}