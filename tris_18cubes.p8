pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

x=0;
t=0;

function rasterize(y,x0,x1,c)
 line(x0,y,x1,y,c)
 return
end

function tri(x0,y0,x1,y1,x2,y2,c)
 local x,xx,y,q,q2;
 if (y0>y1) y=y0;y0=y1;y1=y;x=x0;x0=x1;x1=x;
 if (y0>y2) y=y0;y0=y2;y2=y;x=x0;x0=x2;x2=x;
 if (y1>y2) y=y1;y1=y2;y2=y;x=x1;x1=x2;x2=x;
 local dx01,dy01,dx02,dy02;
 local xd,xxd,c2,fc;
 if (y2<0 or y0>127) return //clip
 c2=shr(c,8);
 if (flr(y0)%2==1) fc=c; c=c2; c2=fc;
 y=y0;
 x=x0;
 xx=x0;
 dx01=x1-x0;
 dy01=y1-y0;
 dy02=y2-y0;
 dx02=x2-x0;
 dx12=x2-x1;
 dy12=y2-y1;
 q2=0;
 xxd=1; if(x2<x0) xxd=-1
 if flr(y0)<flr(y1) then
	 q=0;
	 xd=1; if(x1<x0) xd=-1
		while y<=y1 do
		 fc=c; c=c2; c2=fc;
			rasterize(y,x,xx,fc);
			//line(x,y,xx,y,fc);
			//pset(x,y,7)
			//pset(xx,y,7)
			y+=1;
			q+=dx01;
			q2+=dx02;
			while xd*q>=dy01 do
			 q-=xd*dy01
			 x+=xd
			end
			while xxd*q2>=dy02 do
			 q2-=xxd*dy02
			 xx+=xxd
			end
		end
	end
	
	if flr(y1)<flr(y2) then
		q=0;
		x=x1
		xd=1; if (x2<x1) xd=-1
		while y<=y2 and y<128 do
		 fc=c; c=c2; c2=fc;
			rasterize(y,x,xx,fc);
			
			//line(x,y,xx,y,fc);
			//pset(x,y,7)
			//pset(xx,y,7)
			y+=1;
			q+=dx12;
			q2+=dx02;
			while xd*q>dy12 do
			 q-=xd*dy12
			 x+=xd
			end
			while xxd*q2>dy02 do
			 q2-=xxd*dy02
			 xx+=xxd
			end
		end
	end
	
	//r=(x2-x1)/(y2-y1);
	//while y<y2 do
	//	line(x,y,xx,y,7);
	//	x+=r;
//		xx+=r2;
	//	y+=1;
	//end

 //pset(x0,y0,8);
 //pset(x1,y1,8);
 //pset(x2,y2,8);
end

function tric(a,b,c,d,e,f,g)
 local e1x,e1y,e2x,e2y,xpr;
 e1x=c-a;
 e1y=d-b;
 e2x=e-a;
 e2y=f-b;
 xpr=e1x*e2y-e1y*e2x;
 if (xpr<0) return;
 return tri(a,b,c,d,e,f,g);
end


function rotate(x,y,a)
	local c=cos(a) s=sin(a)
	return c*x-s*y, s*x+c*y
end


function _update()
 t+=1
end


function bg2()
 map(16,0,0,0,16,16)
end

function bg()
 map()
end

function _draw()
 cls();
	for i=1,18 do
	 _draw2(i*199+t);
	end

end

function _draw2(t)
 x+=1
 local r,qt;
 //tri(32,16,32,32,16,40,0xfcfc)
 r=sin(t*0.01)*32+32;
 qt=t*0.01;
 
 -- model
 v={
 	-1,-1,-1, -- 0
 	 1,-1,-1, -- 1
 	-1, 1,-1, -- 2
 	 1, 1,-1, -- 3
 	-1,-1, 1, -- 4
 	 1,-1, 1, -- 5
 	-1, 1, 1, -- 6
 	 1, 1, 1, -- 7
 };
 faces=8;
 f={
  1,0,5,4,
  2,3,6,7,
  0,1,2,3,
  5,4,7,6,
  0,2,4,6,
  3,1,7,5,
 }
 
 objz=sin(t*0.003)*2;
 -- transform
 vt={};
 for i=1,3*8,3 do
 	local x,y,z;
	 -- read
 	x=v[i];
 	y=v[i+1];
 	z=v[i+2];
 	
 	-- process
 	y,z=rotate(y,z,qt*0.9);
 	x,z=rotate(x,z,qt*0.3);
 	x+=sin(t*0.007)*4;
 	y+=sin(t*0.011)*4;
 	z+=objz;
 	z=z+9;
 	x=x*96/z+64;
 	y=y*96/z+64;
 	
  	-- write
 	vt[i]=x;
 	vt[i+1]=y;
 	vt[i+2]=z;
 end
 
 -- material
 mat={
  0x3333,
  0x3333,
  0x3311,
  0x3311,
  0x1111,
  0x1111,
  0x8811,
  0x8811,
  0x8888,
  0x8888,
  0xaa88,
  0xaa88,
  0xaaaa,
  0xaaaa,
  0x77aa,
  0x77aa,
  0x7777
 }
 
 //bg2()
 //bg()
 
  -- triangles
 for i=1,faces*3,4 do
  local a,b,c,d;
  a=f[i];
  b=f[i+1];
  c=f[i+2];
  d=f[i+3];
  
  -- color
  local cc,s;
  s=vt[a*3+2]+vt[b*3+2]+vt[c*3+2]+vt[d*3+2];
  s=s*0.03;
  s=17-s;
  s=mid(1,s,17);
  cc=mat[flr(s)];
  
  tric(
  	vt[a*3+1],
  	vt[a*3+2],
  	vt[b*3+1],
  	vt[b*3+2],
  	vt[c*3+1],
  	vt[c*3+2],
  cc)
  tric(
  	vt[c*3+1],
  	vt[c*3+2],
  	vt[b*3+1],
  	vt[b*3+2],
  	vt[d*3+1],
  	vt[d*3+2],
  cc)
 end
 
 //if (objz>0.9) bg2()
 //if (objz>0.2) bg()
 
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0010000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000000000000100010000000001100000000111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000000000000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000000000000100010000000001111111100111100111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000100010000000000000000000001100000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000100010000000111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000000010000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000000010000000000011110011111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000000010000000000000000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001000000000000000000010000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000000000000000010000000000000000000111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
