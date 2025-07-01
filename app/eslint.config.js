import vitest from "@vitest/eslint-plugin";

export default [
    {
        files: ["**/*.js"], 
        plugins: {
            vitest,
        },
        rules: {
            ...vitest.configs.recommended.rules,
            // Code style rules
            "indent": ["error", 4],
            "semi": ["error", "always"],
            "comma-dangle": ["error", "always-multiline"],
            "quotes": ["error", "double"],
        },
    },
];