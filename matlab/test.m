%% 一些验证的代码
 a=find(events_with_lifetime(:,6)~=0);
 aa=find(events_with_velocity(:,6)~=0);
 b=intersect(a,aa);
 c = setdiff(aa,b);
 
 vxxx=events_with_lifetime(b,5);
 vxxxv=events_with_velocity(b,5);
 figure(1);plot(vxxx);figure(2);plot(vxxxv)
 