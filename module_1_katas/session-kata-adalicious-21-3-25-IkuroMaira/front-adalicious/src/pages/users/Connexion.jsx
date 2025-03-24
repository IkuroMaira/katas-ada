import image from '../../assets/icons/emoji_brocoli.png'
import styles from '../../styles/Connexion.module.css'
import {useState} from "react";

export default function FormFirstname() {
    const [firstName, setFirstName] = useState('');

    function getFirstName() {
        // Récupérer le prénom
        console.log("Le prénom est ", firstName);
    }

    return (
        <>
            <button className={styles.interfaceBtn}> Interface cuisine</button>

            <div className={styles.container}>
                <img className={styles.imgConnexion} src={image} alt="Emoji brocoli" />

                <h1 className={styles.titre}>Bienvenue sur Adalicious</h1>
                <label className={styles.texteIntro}>
                    Pour Commencer, peux-tu me donner ton prénom :

                    <input
                        className={styles.champInput}
                        type="text" name='firstname'
                        placeholder='Gwenaëlle'
                        value={firstName}
                        onChange={e => setFirstName(e.target.value)}/>
                </label>

                <button type='submit' className={styles.validateBtn} onClick={getFirstName}>Valider</button>
            </div>
        </>
    )
}