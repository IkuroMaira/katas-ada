import { useState, useEffect } from "react";

/**
 * useState: hook qui permet de gérer les états
 * useEffect: hook qui permet d'éxsécuter de code à certains moments du composant
 */

/**
 * Hook pour gérer les requêtes AÏ
 */

// On commence apr "use", dans la convention React et permet d'identifier les hooks
function useAPI(url) {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetch(url)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Erreur lors de la requête');
                }
                return response.json();
            })
            .then(result => {
                setData(result);
                setLoading(false);
            })
            .catch(err => {
                setError(err.message);
                setLoading(false);
            });
    }, [url]);

    return { data, loading, error };
}

export default useAPI;