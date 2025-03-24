import './App.css'
import {BrowserRouter, Route, Routes} from "react-router-dom";
import Home from "./pages/users/Home.jsx";
import Menu from "./pages/users/Menu.jsx";

function App() {

  return (
    <>
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/menu" element={<Menu />} />
            </Routes>
        </BrowserRouter>
    </>
  )
}

export default App
