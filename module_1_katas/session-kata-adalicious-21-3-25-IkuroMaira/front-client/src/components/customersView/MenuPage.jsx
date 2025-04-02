import CardPlate from "../menu/CardPlate.jsx";
import Header from "../common/Header.jsx";
import styles from "./MenuPage.module.css"
import React, { useState, useEffect } from "react";

export default function MenuPage() {
    const [menu, setMenu] = useState([]);

    useEffect(() => {
        const fetchMenu = async () => {
            const response = await fetch('http://localhost:5002/menu');
            const data = await response.json();
            setMenu(data);
        };

        fetchMenu();
    }, []);

    return (
        <>
            <Header />

            <h1 className={styles.firstNameTitle}>Bonjour {/*{firstName}*/}</h1>

            <div className={styles.containerMenu}>
                {menu.map((plate) => (
                    <CardPlate key={plate.id} plate={plate} />
                ))}
            </div>
        </>
    )
}