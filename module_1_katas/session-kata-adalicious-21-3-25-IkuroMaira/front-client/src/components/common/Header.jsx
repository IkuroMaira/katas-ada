import styles from './Header.module.css';

export default function Header() {
    return (
        <>
            <nav className={styles.header}>
                <h1 className={styles.title}>Adalicious 🥦</h1>
            </nav>
        </>
    )
}