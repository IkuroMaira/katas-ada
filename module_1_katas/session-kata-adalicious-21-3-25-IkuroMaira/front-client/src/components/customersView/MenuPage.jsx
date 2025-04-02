import CardPlate from "../menu/CardPlate.jsx";
import Header from "../common/Header.jsx";
import styles from "./MenuPage.module.css"
import React, { useState, useEffect } from "react";
import { useLocation } from "react-router-dom"; // sert à récupérer les données passées lors de la Navigation

export default function MenuPage() {
    const [menu, setMenu] = useState([]);
    // Permet de récupérer les données passées via Naviagate
    const location = useLocation();
    // Ajouter une condition si le prénom n'est pas récupérer
    const firstName = location.state.firstName;

    // Les états pour gérer le chargement
        // Peut-être créer un composant qui va gérer les chargements des données dans les pages
    const [loading, setLoading] = useState(true);
    const [menuItems, setMenuItems] = useState([]);

    useEffect(() => {
        // Ici on charge les données depuis le serveur/API
        const fetchMenuData = async () => {
            // TODO: ajouter une gestion d'erreur
            try {
                const response = await fetch('http://localhost:5002/menu');
                const data = await response.json();

                setMenu(data);

                setLoading(false);
            } catch (error) {
                console.log("Erreur lors du chargement du Menu: ", error);
                setLoading(false);
            }
        };

        fetchMenuData();
    }, []);

    return (
        <>
            <Header />

            <h1 className={styles.firstNameTitle}>Bonjour {firstName}</h1>

            {loading ?
                <div className={styles.loadingContainer}>
                    <p>Chargement du menu en cours...</p>
                </div>
                :
                <div className={styles.containerMenu}>
                    {menu.map((plate) => (
                        <CardPlate key={plate.id} plate={plate} />
                    ))}
                </div>
            }
        </>
    )
}