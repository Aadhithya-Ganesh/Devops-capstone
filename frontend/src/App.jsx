import { useState } from "react";

function App() {
  const [status, setStatus] = useState("Idle");

  const makeRequest = async () => {
    try {
      const response = await fetch(`/api/hello`, {
        method: "GET",
      });

      if (!response.ok) {
        throw new Error("Request failed");
      }

      setStatus("Success");
    } catch (error) {
      setStatus("Failure");
    }
  };

  return (
    <div>
      <button onClick={makeRequest}>Send Request</button>

      <p>Status: {status}</p>
    </div>
  );
}

export default App;
