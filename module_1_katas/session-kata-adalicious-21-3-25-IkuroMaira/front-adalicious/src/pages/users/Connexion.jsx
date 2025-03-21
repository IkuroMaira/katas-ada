import image from '../../assets/icons/emoji_brocoli.png'
import styles from '../../styles/Connexion.module.css'
import {useState} from "react";

export default function Connexion() {
    const [name, setName] = useState('');

    function getName() {
        // setName();
        console.log(name);
    }

    return (
        <>
            <button className={styles.interfaceBtn}> Interface cuisine</button>

            <div className={styles.container}>
                <img className={styles.imgConnexion} src={image} alt="Emoji brocoli" />

                <h1 className={styles.titre}>Bienvenue sur Adalicious</h1>
                <p className={styles.texteIntro}>Pour Commencer, peux-tu me donner ton prénom : </p>
                <input className={styles.champInput}/>
                <button className={styles.validateBtn} onClick={getName}>Valider</button>
            </div>
        </>
    )
}