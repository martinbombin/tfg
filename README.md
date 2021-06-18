# tfg
Cálculo de elementos finitos con redes neuronales convolucionales

Se incluye en archivo de Colab con la red y la distribución de muestras usadas para su entrenamiento y testeo.

Se incluye el directorio con todo lo necesario para generar las muestras de entrenamiento (Muestras de entrenamiento conseguidas en el formato de Numpy: https://drive.google.com/file/d/1AIaiq_QzCeJ52u_ZiEJ5xQNAXshkOa14/view?usp=sharing).

Se incluyen los pesos de la red entrenada sobre las muestras del artículo original (1k.h5) y los pesos de la red entrenada sobre la anterior que mejor resultados nos ha dado con nuestras muestras, donde se congelaban las 10 primeras capas con gelando solo los BN de las capas SE-Res.
