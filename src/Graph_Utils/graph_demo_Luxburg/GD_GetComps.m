function [c] = GD_GetComps(A)
n = size(A,1);
c = zeros(n,1);
clNo = 1;
q = zeros(n,1);
qptr = 1;
qlen = 0;
for i = 1:n,
    if (c(i) == 0),
        c(i) = clNo;
        qlen = qlen + 1;
        q(qlen) = i;
        while (qptr <= qlen)
            j = q(qptr);

            nbrs = find(A(:,j));
            for nbr = nbrs';
                if (c(nbr) == 0),
                    qlen = qlen + 1;
                    q(qlen) = nbr;
                    c(nbr) = clNo;
                end
            end
            qptr = qptr + 1;
        end

        clNo = clNo + 1;
    end
end
