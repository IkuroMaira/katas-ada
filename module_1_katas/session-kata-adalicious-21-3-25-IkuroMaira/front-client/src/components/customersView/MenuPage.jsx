import CardPlate from "../menu/CardPlate.jsx";
import Header from "../common/Header.jsx";
import styles from "./MenuPage.module.css"

export default function MenuPage() {
    return (
        <>
            <Header />

            <h1 className={styles.firstNameTitle}>Bonjour {/*{firstName}*/}</h1>
            <CardPlate />
        </>
    )
}