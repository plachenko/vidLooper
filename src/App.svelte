<script lang="ts">
	import { onMount } from "svelte";

	export let name: string;
	let video: HTMLVideoElement;
	let can: HTMLCanvasElement;
	let ctx: WebGL2RenderingContext;

	function setupGL(){
		ctx.viewport(0, 0, ctx.drawingBufferWidth, ctx.drawingBufferHeight)
		ctx.clearColor(1.0, 0.3, 0.3, 1.0);
		ctx.clear(ctx.COLOR_BUFFER_BIT);

		const vertShader = `
			attribute vec2 position;

			varying vec2 texCoords;

			void main(){
				texCoords = (position + 1.0) / 2.0;
				texCoords.y = 1.0 - texCoords.y;
				gl_Position = vec4(position, 0, 1.0);
			}

		`;

		const fragShader = `
			precision highp float;

			varying vec2 texCoords;

			uniform sampler2D textureSampler;
			
			void main(){
				float alpha = 0.2;

				vec4 color = texture2D(textureSampler, texCoords);

				color.a += alpha;

				gl_FragColor = color;
			}
		`;

				/* gl_FragColor = vec4(texCoords, 1.0, 1.0); */
				/* gl_FragColor = texture2D(textureSampler, texCoords); */

		const vertShaderObj = ctx.createShader(ctx.VERTEX_SHADER)
		const fragShaderObj = ctx.createShader(ctx.FRAGMENT_SHADER)

		ctx.shaderSource(vertShaderObj, vertShader);
		ctx.shaderSource(fragShaderObj, fragShader);

		ctx.compileShader(vertShaderObj);
		ctx.compileShader(fragShaderObj);

		const program = ctx.createProgram();
		ctx.attachShader(program, vertShaderObj);
		ctx.attachShader(program, fragShaderObj);

		ctx.linkProgram(program);
		ctx.useProgram(program);

		const vertices = new Float32Array([
			-1, -1,
			-1, 1,
			1, 1,

			-1, -1,
			1, 1,
			1, -1
		]);

		const vertBuffer = ctx.createBuffer();
		ctx.bindBuffer(ctx.ARRAY_BUFFER, vertBuffer);
		ctx.bufferData(ctx.ARRAY_BUFFER, vertices, ctx.STATIC_DRAW);

		const positionLocation = ctx.getAttribLocation(program, 'position')
		ctx.vertexAttribPointer(positionLocation, 2, ctx.FLOAT, false, 0, 0)
		ctx.enableVertexAttribArray(positionLocation);

		const texture = ctx.createTexture();
		ctx.activeTexture(ctx.TEXTURE0);
		ctx.bindTexture(ctx.TEXTURE_2D, texture);
		ctx.texImage2D(ctx.TEXTURE_2D, 0, ctx.RGBA, ctx.RGBA, ctx.UNSIGNED_BYTE, video);

		ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_S, ctx.CLAMP_TO_EDGE);
		ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_T, ctx.CLAMP_TO_EDGE);
		ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_MIN_FILTER, ctx.LINEAR);

		ctx.drawArrays(ctx.TRIANGLES, 0, 6);

		/* console.log(ctx.getProgramInfoLog(program)) */
		/* console.log(ctx.getShaderInfoLog(fragShaderObj)) */

	}

	const draw = ()=>{
		setupGL();
		/* console.log('drawing'); */
		/* ctx.texImage2D(ctx.TEXTURE_2D, 0, ctx.RGBA, ctx.RGBA, ctx.UNSIGNED_BYTE, video); */
		requestAnimationFrame(draw);
	}

	onMount(()=>{
		/* can.width = window.innerWidth; */
		/* can.height = window.innerHeight; */
		console.log(can);

		ctx = can.getContext('webgl2');
		video.addEventListener("playing", ()=>{
			draw();
			setupGL();
		});

		navigator.mediaDevices.getUserMedia({video: true}).then((sObj)=>{
			video.srcObject = sObj;
		}).catch((err)=>{
			console.log(err);
		});
	});
	
</script>

<main>
	<canvas bind:this={can}></canvas>
	<video bind:this={video} autoplay={true} id="vid"></video>
</main>

<style>
	main {
		text-align: center;
		width: 100%;
		height: 100%;
	}

	h1 {
		color: #ff3e00;
		text-transform: uppercase;
		font-size: 4em;
		font-weight: 100;
	}

	canvas{
		/* width: 100%; */
		/* height: 100%; */
	}
	video{
		/* display: none; */
	}
</style>
