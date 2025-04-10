import { BrowserRouter, Route, Routes } from "react-router-dom";
import HomePage from "../../front-client/src/components/customersView/HomePage.jsx";
import MenuPage from "../../front-client/src/components/customersView/MenuPage.jsx";

function App() {

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
