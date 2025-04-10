import React, {useEffect, useState} from "react";
import styles from './DetailsOrder.module.css';
import { useLocation } from "react-router-dom";

const port= 5002;

export default function DetailsOrder() {
    const location = useLocation();
    const idPlate= location.state.idPlate;
    const [listPlates, setListPlates] = useState([]);

    useEffect(() => {
        const fetchPlateData = async (idPlate) => {
            try {
                const res = await fetch(`http://localhost:${port}/menu/${idPlate}`);
                const data = await res.json();
                console.log(data);

                setListPlates(data);
            } catch (error) {
                console.log("Erreur lor de la récupération du plat: ", error);
            }
        };

        fetchPlateData(idPlate);
    }, []);

    return (
        <>
            <div className={styles.containerOrder}>
                <h3 className={styles.title}>Détails de la commande</h3>
                {/*<p className={styles.listOrder}>{listPlates.map((plate) => (*/}
                {/*    */}
                {/*)}</p>*/}
            </div>
        </>
    )
}