function configureGridAndLabels(yticklabel_flags, xticklabel_flags, i, j)
    if yticklabel_flags(i, j) == 1 
        if xticklabel_flags(i, j) == 1
            m_grid('box','on','linest','none','linewidth',1.5,'tickdir','in','backcolor',[1 1 1],'fontname','Time New Roman','fontsize',20,'FontWeight','bold');
        else
            m_grid('box','on','linest','none','linewidth',1.5,'tickdir','in','backcolor',[1 1 1],'fontname','Time New Roman','fontsize',15,'FontWeight','bold', 'XTickLabel', '');
        end
    else
        if xticklabel_flags(i, j) == 1
            m_grid('box','on','linest','none','linewidth',1.5,'tickdir','in','backcolor',[1 1 1],'fontname','Time New Roman','fontsize',20,'FontWeight','bold', 'YTickLabel', '');
        else
            m_grid('box','on','linest','none','linewidth',1.5,'tickdir','in','backcolor',[1 1 1],'fontname','Time New Roman','fontsize',20,'FontWeight','bold', 'YTickLabel', '', 'XTickLabel', '');
        end
    end
    set(gca, 'fontsize',20,'FontName','Times New Roman','FontWeight','bold');
end