import React, { useEffect, useState } from "react";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import HomePage from "../../front-client/src/components/customersView/HomePage.jsx";
import MenuPage from "../../front-client/src/components/customersView/MenuPage.jsx";

function App() {

    const [backendData, setBackendData] = useState([{}]);

    useEffect(() => {
        // On indique la route
        fetch('/api').then(
            response => response.json()
        ).then(
            data => {
                setBackendData(data)
            }
        )
    }, [])

    return (
        <>
            <BrowserRouter>
                <div>
                    {/* Affichage des données pour test */}
                    {(typeof backendData.message === 'undefined') ? (
                        <p>Chargement des données...</p>
                    ) : (
                        <div>
                            <h2>Données du serveur:</h2>
                            <p>{backendData.message}</p>
                            <ul>
                                {backendData.items && backendData.items.map((item, i) => (
                                    <li key={i}>{item}</li>
                                ))}
                            </ul>
                        </div>
                    )}
                </div>

                <Routes>
                    <Route path="/" element={<HomePage />} />
                    <Route path="/menu" element={<MenuPage />} />
                </Routes>
            </BrowserRouter>
        </>
    )
}

export default App
