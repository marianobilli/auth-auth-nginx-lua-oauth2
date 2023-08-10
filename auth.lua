-- ================================================
-- Group Authentication via x-groups and x-username
-- ================================================
function group_matches()
  if not ngx.var.authorized_groups or not ngx.var.user_groups then
    return false
  end
  local match_found = false

  -- check each authorized group/pattern with against each user group
  for authorized_group in string.gmatch(ngx.var.authorized_groups, "([^,]+)") do
    match_found = false
    for user_group in string.gmatch(ngx.var.user_groups, "([^,]+)") do
      if string.match(user_group, authorized_group) then
        if not ngx.var.conditional_groups or string.lower(ngx.var.conditional_groups) == "or" then
            return true
        end
        if ngx.var.conditional_groups and string.lower(ngx.var.conditional_groups) == "and" then
          match_found = true
          break
        end
      end
    end
    if ngx.var.conditional_groups and string.lower(ngx.var.conditional_groups) == "and" and not match_found then
      return false
    end
  end
  return match_found
end

function user_matches()
  if not ngx.var.authorized_users or not ngx.var.user then
    return false
  end

  for authorized_user in string.gmatch(ngx.var.authorized_users, "([^,]+)") do
    if string.match(ngx.var.user, authorized_user) then
      return true
    end
  end
  return false
end

-------- MAIN LOGIC --------
if ngx.var.conditional_user_groups and string.lower(ngx.var.conditional_user_groups) == "and" then
  if group_matches() and user_matches() then
    found = true
  end
end

if not ngx.var.conditional_user_groups or string.lower(ngx.var.conditional_user_groups) == "or" then
  if group_matches() or user_matches() then
    found = true
  end
end

if not found then
  ngx.exit(ngx.HTTP_FORBIDDEN)
end
