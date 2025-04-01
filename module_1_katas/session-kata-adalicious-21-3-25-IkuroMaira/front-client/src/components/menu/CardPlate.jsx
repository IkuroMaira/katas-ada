import styles from './CardPlate.module.css';
import image from '../../assets/icons/emoji_brocoli.png';

export default function CardPlate() {
    return (
        <>
            <div className={styles.platCard}>
                <img className={styles.platImage} src={image} alt="Nom du plat"/>
                <div className={styles.platInfos}>
                    <h1 className={styles.platTitle}>{}</h1>
                    <p className={styles.platDescription}>{}</p>
                    <button className={styles.btnOrder}>Commander</button>
                </div>
            </div>
        </>
    )
}