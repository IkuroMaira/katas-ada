import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import image from '../../assets/icons/emoji_brocoli.png'
import styles from './HomePage.module.css'

const port= 5002;

export default function HomePage() {
    const [firstName, setFirstName] = useState('');

    const addUser = async (firstName) => {
        try {
            const res = await fetch(`http://localhost:${port}/api/users`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ firstName })
            });


            const data = await res.json();
            console.log('Utilisateur ajouté avec succès:', data);
            return data;
        } catch (error) {
            console.log('Erreur:', error);
        }
    }

    // Changer de page
    const navigate = useNavigate();

    // Pour la soumission du formulaire
    const handleSubmit = (event) => {
        // Empêche le comportement par défaut du formulaire (rechargement de la page)
        // Aller comprendre mieux ce truc du comportement par défaut, React en parle aussi
        event.preventDefault();

        if (firstName) {
            // console.log("Prénom: ", firstName);
            navigate('/menu', { state: { firstName } });
            addUser(firstName); // Pour envoyer au back
        } else {
            const errorMessage = "Veuillez rentrer votre prénom.";
            console.log("Le prénom n'est pas rentré !");
        }
    }

    return (
        <>
            <div className={styles.homeContainer}>
                <button className={styles.interfaceBtn}> Interface cuisine</button>

                <div className={styles.container}>
                    <img className={styles.imgConnexion} src={image} alt="Emoji brocoli" />

                    <h1 className={styles.titre}>Bienvenue sur Adalicious</h1>
                    <label className={styles.texteIntro}>
                        Pour commencer, peux-tu me donner ton prénom :

                        <input
                            className={styles.champInput}
                            type="text" name='firstname'
                            placeholder='Gwenaëlle'
                            value={firstName}
                            onChange={e => setFirstName(e.target.value)}
                            required
                        />

                        <p className={styles.errorMessage}></p>
                    </label>

                    {/*Redirection programmatique*/}
                    <button type='submit' className={styles.validateBtn} onClick={handleSubmit}>Valider</button>
                </div>
            </div>
        </>
    )
}