#version 330 core
out vec4 FragColor;

in vec4 vertexColor;

void main()
{
    FragColor = vertexColor;
}

// bottom left is black as the x,y coords are negative here, and thus their color clamped
// to 0 => (0,0,0) is black
