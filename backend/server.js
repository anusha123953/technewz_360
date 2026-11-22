// UNIVERSAL API FETCH FUNCTION
async function fetchAPI(url, options = {}, timeout = 15000) {
    try {
        const response = await fetch(url, {
            ...options,
            signal: AbortSignal.timeout(timeout)
        });

        const text = await response.text();

        let data;

        try {
            data = JSON.parse(text);
        } catch {
            throw new Error("Invalid API response.");
        }

        if (!response.ok) {
            const errorDetails =
                data.errors
                    ? JSON.stringify(data.errors)
                    : data.error?.message ||
                      data.message ||
                      JSON.stringify(data);

            const error = new Error(
                `API error ${response.status}: ${errorDetails}`
            );

            error.status = response.status;
            throw error;
        }

        return data;

    } catch (error) {

        if (
            error.name === "TimeoutError" ||
            error.name === "AbortError"
        ) {
            const timeoutError = new Error(
                `API timeout after ${timeout / 1000} seconds`
            );

            timeoutError.status = 504;
            throw timeoutError;
        }

        throw error;
    }
}