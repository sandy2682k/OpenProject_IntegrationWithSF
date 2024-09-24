<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Google Drive Image Preview</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f4f4f4;
            margin: 0;
        }
        .container {
            text-align: center;
            background: #fff;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }
        img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Image Preview</h1>
        <!-- Replace YOUR_FILE_ID with your actual file ID from Google Drive -->
        <img src="https://drive.google.com/uc?export=view&id=1-UCfE2wo-EMZigrXRMuElrrvVJ4TNxcQ" alt="Google Drive Image">
    </div>
</body>
</html>
