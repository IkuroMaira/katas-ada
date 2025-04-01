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
                <Routes>
                    <Route path="/" element={<HomePage />} />
                    <Route path="/menu" element={<MenuPage />} />
                </Routes>
            </BrowserRouter>
        </>
    )
}

export default App
